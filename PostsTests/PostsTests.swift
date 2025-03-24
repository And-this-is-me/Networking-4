import Testing
@testable import Posts

final class ApiClientTests {
    
    var sut: ApiClient!
    
    init() {
        sut = .mockup()
    }
    
    @Test
    func testRequestPosts_withDistinctiveValues_validatesEachPost() async {
        // When
        do {
            let posts = try await sut.requestPosts(FetchPostsRequest())
            
            // Then
            #expect(posts.count == 3,                   "Expected 3 posts but got \(posts.count)")
            #expect(posts[0].id == 1,                   "First post ID does not match")
            #expect(posts[0].userID == 1,               "First post user ID does not match")
            #expect(posts[0].title == "Title 1",        "First post title does not match")
            // Add more assertions as needed
        } catch {
            #expect(Bool(false), "Error fetching posts: \(error.localizedDescription)")
        }
    }
    
    @Test
    func testAddingPost_withDistinctiveValues_validatesAddedPost() async {
        // Given
        let newPostRequest = AddPostRequest(title: "New Post", body: "Body of new post", userID: 4)
        
        // When
        do {
            let addedPost = try await sut.addPost(newPostRequest)
            
            // Then
            #expect(addedPost.userID == 4,          "Added post user ID should match")
            #expect(addedPost.title == "New Post",  "Added post title should match")
            // Add more assertions as needed
        } catch {
            #expect(Bool(false), "Error adding posts: \(error.localizedDescription)")
        }
    }
    
    @Test
    func testUpdatingPost_withDistinctiveValues_validatesUpdatedPost() async {
        // Given
        let updatedPostRequest = UpdatePostRequest(id: 3, title: "Updated Title 3", body: "Updated Body 3", userID: 4)
        
        // When
        do {
            let updatePost = try await sut.updatePost(updatedPostRequest)
            
            // Then
            #expect(updatePost.id == 3,                         "Updated post ID should match")
            #expect(updatePost.userID == 4,                     "Updated post user ID should match")
            #expect(updatePost.title == "Updated Title 3",      "Updated post title should match")
            #expect(updatePost.body == "Updated Body 3",        "Updated post body should match")
            
        } catch {
            #expect(Bool(false), "Error updating posts: \(error.localizedDescription)")
        }
    }
    
    @Test
    func testPatchingPost_withDistinctiveValues_validatesPatchedPost() async {
        // Given
        let patchPostRequest = PatchPostRequest(id: 3, body: "Patched Body 3")
        
        // When
        do {
            let patchPost = try await sut.patchPost(patchPostRequest)
            
            // Then
            #expect(patchPost.id == 3,                         "Patched post ID should match")
            #expect(patchPost.body == "Patched Body 3",        "Patched post body should match")
            
        } catch {
            #expect(Bool(false), "Error patching posts: \(error.localizedDescription)")
        }
    }
    
    @Test
    func testRemovingPost_withProvidedPostID_validatesRemovedPost() async {
        // Given
        let deletePostRequest = RemovePostRequest(id: 3)
        
        // When
        do {
            try await sut.removePost(deletePostRequest)
            let posts = try await sut.requestPosts(FetchPostsRequest())
            
            // Then
            #expect(posts.count == 2, "Expected 3 posts but got \(posts.count)")
            
        } catch {
            #expect(Bool(false), "Error removing posts: \(error.localizedDescription)")
        }
    }
}

class TestingPosts {
    var data: [Post] = Post.testing
}

extension ApiClient {
    static func mockup() -> ApiClient {
        var posts: TestingPosts = .init()
        
        // Define mock data and behavior for requesting posts
        let requestingPosts: @Sendable (FetchPostsRequest) async throws -> [Post] = { [posts] _ in
            return posts.data
        }
        
        // Define mock data and behavior for adding post
        let addingPost: @Sendable (AddPostRequest) async throws -> Post = { [posts] request in
            let post = Post(id: 0, body: request.body, title: request.title, userID: request.userID)
            posts.data.append(post)
            return post
        }
        
        // Define mock data and behavior for updating post
        let updatePost: @Sendable (UpdatePostRequest) async throws -> Post = { [posts] request in
            guard let i = posts.data.firstIndex(where: { $0.id == request.id }) else {
                throw ApiClientError.undefined(message: "No post to update found")
            }
            
            let post = Post(id: posts.data[i].id, body: request.body, title: request.title, userID: request.userID)
            posts.data[i] = post
            return post
        }
        
        // Define mock data and behavior for patching post
        let patchPost: @Sendable (PatchPostRequest) async throws -> Post = { [posts] request in
            guard let index = posts.data.firstIndex(where: { $0.id == request.id }) else {
                    throw ApiClientError.undefined(message: "No post found to patch")
                }
                
            let existingPost = posts.data[index]
                
                // Apply partial updates from the request
                let updatedPost = Post(
                    id: existingPost.id,
                    body: request.body ?? existingPost.body,
                    title: request.title ?? existingPost.title,
                    userID: existingPost.userID
                )
                
                // Update the post in the array
            posts.data[index] = updatedPost
                
                return updatedPost
        }
        
        let removePost: @Sendable (RemovePostRequest) async throws -> Void = { [posts] request in
            guard let i = posts.data.firstIndex(where: { $0.id == request.id }) else {
                throw ApiClientError.undefined(message: "No post to delete found")
            }
            
            posts.data.remove(at: i)
        }
        
        // Create mock ApiClient with the defined behaviors
        return ApiClient(
            requestPosts: requestingPosts,
            addPost: addingPost,
            updatePost: updatePost,
            patchPost: patchPost,
            removePost: removePost
        )
    }
}

extension Post {
    static let testing: [Self] = [
        .init(id: 1, body: "Body 1", title: "Title 1", userID: 1),
        .init(id: 2, body: "Body 2", title: "Title 2", userID: 2),
        .init(id: 3, body: "Body 3", title: "Title 3", userID: 3)
    ]
}
