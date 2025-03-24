//
//  ContentView.swift
//  Posts
//
//

import SwiftUI

struct ContentView: View {
    
    private var apiClient = ApiClient.live()
    
    @State var posts: [Post]?
    
    var body: some View {
        NavigationView {
            Group {
                VStack {
                    if let posts {
                        List {
                            ForEach(posts) { post in
                                VStack(alignment: .leading) {
                                    Text("\(post.title)")
                                        .font(.headline)
                                    Text("\(post.body)")
                                        .font(.subheadline)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        Task {
                                            await deletePost(post)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        Task {
                                            await updatePost(post)
                                        }
                                    } label: {
                                        Label("Update", systemImage: "pencil")
                                    }
                                    
                                    Button {
                                        Task {
                                            await patchPost(post)
                                        }
                                    } label: {
                                        Label("Patch", systemImage: "doc.text.fill")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Posts")
            .navigationBarItems(trailing:
                Button(action: {
                    Task {
                        await addRandomPost()
                    }
                }) {
                    Text("Add")
                }
            )
        }
        .task {
            await loadPosts()
        }
    }
    
    // Function to load posts
    func loadPosts() async {
        do {
            posts = try await apiClient.requestPosts(.init())
        } catch {
            print(error)
        }
    }
    
    // Function to add a new random post
    func addRandomPost() async {
        do {
            let post = try await apiClient.addPost(.init(
                title: "Added post",
                body: "Added post on \(Date.printNow())",
                userID: 1)
            )
            posts?.append(post)
        } catch {
            print(error)
        }
    }
    
    // Function to update an existing post (PUT)
    func updatePost(_ post: Post) async {
        do {
            let updatedPost = try await apiClient.updatePost(.init(
                id: post.id,
                title: "Updated Title",
                body: "Updated body on \(Date.printNow())",
                userID: post.userID
            ))
            if let index = posts?.firstIndex(where: { $0.id == post.id }) {
                posts?[index] = updatedPost
            }
        } catch {
            print(error)
        }
    }
    
    // Function to patch an existing post (PATCH)
    func patchPost(_ post: Post) async {
        do {
            let patchedPost = try await apiClient.patchPost(.init(
                id: post.id,
                title: "Patched Title"
            ))
            if let index = posts?.firstIndex(where: { $0.id == post.id }) {
                posts?[index] = patchedPost
            }
        } catch {
            print(error)
        }
    }
    
    // Function to delete a post
    func deletePost(_ post: Post) async {
        do {
            try await apiClient.removePost(.init(id: post.id))
            posts?.removeAll { $0.id == post.id }
        } catch {
            print(error)
        }
    }
}

extension Date {
    static func printNow() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let dateTimeString = formatter.string(from: Date())
    }
}
