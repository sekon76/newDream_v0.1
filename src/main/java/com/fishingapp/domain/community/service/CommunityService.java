package com.fishingapp.domain.community.service;

import com.fishingapp.domain.community.dto.CommunityPostDetail;
import com.fishingapp.domain.community.dto.CommunityPostSummary;
import com.fishingapp.domain.community.repository.CommentRepository;
import com.fishingapp.domain.community.repository.PostLikeRepository;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.point.repository.PointVisitRepository;
import com.fishingapp.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommunityService {

    private final PointVisitRepository pointVisitRepository;
    private final PostLikeRepository postLikeRepository;
    private final CommentRepository commentRepository;

    public Page<CommunityPostSummary> getPosts(User user, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size,
                Sort.by("visitDate").descending().and(Sort.by("createdAt").descending()));
        return pointVisitRepository.findPublicPosts(pageable)
                .map(visit -> new CommunityPostSummary(visit,
                        postLikeRepository.countByPointVisit(visit),
                        commentRepository.countByPointVisit(visit),
                        postLikeRepository.existsByPointVisitAndUser(visit, user)));
    }

    public CommunityPostDetail getPost(User user, Long visitId) {
        PointVisit visit = pointVisitRepository.findPublicById(visitId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않거나 비공개 일지입니다."));
        return new CommunityPostDetail(visit,
                postLikeRepository.countByPointVisit(visit),
                commentRepository.countByPointVisit(visit),
                postLikeRepository.existsByPointVisitAndUser(visit, user));
    }
}
