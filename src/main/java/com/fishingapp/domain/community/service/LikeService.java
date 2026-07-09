package com.fishingapp.domain.community.service;

import com.fishingapp.domain.community.dto.LikeResponse;
import com.fishingapp.domain.community.entity.PostLike;
import com.fishingapp.domain.community.repository.PostLikeRepository;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.point.repository.PointVisitRepository;
import com.fishingapp.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LikeService {

    private final PointVisitRepository pointVisitRepository;
    private final PostLikeRepository postLikeRepository;

    @Transactional
    public LikeResponse like(User user, Long visitId) {
        PointVisit visit = getPublicVisit(visitId);
        if (postLikeRepository.existsByPointVisitAndUser(visit, user)) {
            throw new IllegalArgumentException("이미 좋아요를 눌렀습니다.");
        }
        postLikeRepository.save(PostLike.builder().pointVisit(visit).user(user).build());
        return buildResponse(visit, user);
    }

    @Transactional
    public void unlike(User user, Long visitId) {
        PointVisit visit = getPublicVisit(visitId);
        PostLike like = postLikeRepository.findByPointVisitAndUser(visit, user)
                .orElseThrow(() -> new IllegalArgumentException("좋아요를 누르지 않았습니다."));
        postLikeRepository.delete(like);
    }

    private LikeResponse buildResponse(PointVisit visit, User user) {
        long count = postLikeRepository.countByPointVisit(visit);
        boolean liked = postLikeRepository.existsByPointVisitAndUser(visit, user);
        return new LikeResponse(count, liked);
    }

    private PointVisit getPublicVisit(Long visitId) {
        return pointVisitRepository.findPublicById(visitId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않거나 비공개 일지입니다."));
    }
}
