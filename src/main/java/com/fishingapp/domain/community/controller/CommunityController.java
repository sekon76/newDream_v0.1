package com.fishingapp.domain.community.controller;

import com.fishingapp.domain.community.dto.CommentCreateRequest;
import com.fishingapp.domain.community.dto.CommentResponse;
import com.fishingapp.domain.community.dto.CommentUpdateRequest;
import com.fishingapp.domain.community.dto.CommunityPostDetail;
import com.fishingapp.domain.community.dto.CommunityPostSummary;
import com.fishingapp.domain.community.dto.LikeResponse;
import com.fishingapp.domain.community.service.CommentService;
import com.fishingapp.domain.community.service.CommunityService;
import com.fishingapp.domain.community.service.LikeService;
import com.fishingapp.domain.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/community")
@RequiredArgsConstructor
public class CommunityController {

    private final CommunityService communityService;
    private final LikeService likeService;
    private final CommentService commentService;

    @GetMapping("/posts")
    public ResponseEntity<Page<CommunityPostSummary>> getPosts(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(communityService.getPosts(user, page, size));
    }

    @GetMapping("/posts/{visitId}")
    public ResponseEntity<CommunityPostDetail> getPost(
            @AuthenticationPrincipal User user,
            @PathVariable Long visitId) {
        return ResponseEntity.ok(communityService.getPost(user, visitId));
    }

    @PostMapping("/posts/{visitId}/likes")
    public ResponseEntity<LikeResponse> like(
            @AuthenticationPrincipal User user,
            @PathVariable Long visitId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(likeService.like(user, visitId));
    }

    @DeleteMapping("/posts/{visitId}/likes")
    public ResponseEntity<Void> unlike(
            @AuthenticationPrincipal User user,
            @PathVariable Long visitId) {
        likeService.unlike(user, visitId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/posts/{visitId}/comments")
    public ResponseEntity<List<CommentResponse>> getComments(@PathVariable Long visitId) {
        return ResponseEntity.ok(commentService.findAll(visitId));
    }

    @PostMapping("/posts/{visitId}/comments")
    public ResponseEntity<CommentResponse> createComment(
            @AuthenticationPrincipal User user,
            @PathVariable Long visitId,
            @Valid @RequestBody CommentCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(commentService.create(user, visitId, request));
    }

    @PutMapping("/comments/{commentId}")
    public ResponseEntity<CommentResponse> updateComment(
            @AuthenticationPrincipal User user,
            @PathVariable Long commentId,
            @Valid @RequestBody CommentUpdateRequest request) {
        return ResponseEntity.ok(commentService.update(user, commentId, request));
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<Void> deleteComment(
            @AuthenticationPrincipal User user,
            @PathVariable Long commentId) {
        commentService.delete(user, commentId);
        return ResponseEntity.noContent().build();
    }
}
