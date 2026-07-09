package com.fishingapp.domain.community.service;

import com.fishingapp.domain.community.dto.CommentCreateRequest;
import com.fishingapp.domain.community.dto.CommentResponse;
import com.fishingapp.domain.community.dto.CommentUpdateRequest;
import com.fishingapp.domain.community.entity.Comment;
import com.fishingapp.domain.community.repository.CommentRepository;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.point.repository.PointVisitRepository;
import com.fishingapp.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommentService {

    private final PointVisitRepository pointVisitRepository;
    private final CommentRepository commentRepository;

    public List<CommentResponse> findAll(Long visitId) {
        PointVisit visit = getPublicVisit(visitId);
        return commentRepository.findAllByPointVisitOrderByCreatedAtAsc(visit)
                .stream()
                .map(CommentResponse::new)
                .toList();
    }

    @Transactional
    public CommentResponse create(User user, Long visitId, CommentCreateRequest request) {
        PointVisit visit = getPublicVisit(visitId);
        Comment comment = Comment.builder()
                .pointVisit(visit)
                .user(user)
                .content(request.getContent())
                .build();
        return new CommentResponse(commentRepository.save(comment));
    }

    @Transactional
    public CommentResponse update(User user, Long commentId, CommentUpdateRequest request) {
        Comment comment = getOwnedComment(user, commentId);
        comment.updateContent(request.getContent());
        return new CommentResponse(comment);
    }

    @Transactional
    public void delete(User user, Long commentId) {
        commentRepository.delete(getOwnedComment(user, commentId));
    }

    private Comment getOwnedComment(User user, Long commentId) {
        return commentRepository.findByIdAndUser(commentId, user)
                .orElseThrow(() -> new IllegalArgumentException("댓글을 찾을 수 없습니다."));
    }

    private PointVisit getPublicVisit(Long visitId) {
        return pointVisitRepository.findPublicById(visitId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않거나 비공개 일지입니다."));
    }
}
