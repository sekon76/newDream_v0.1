package com.fishingapp.domain.community.service;

import com.fishingapp.domain.community.dto.CommunityPostDetail;
import com.fishingapp.domain.community.dto.CommunityPostSummary;
import com.fishingapp.domain.point.repository.PointVisitRepository;
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

    public Page<CommunityPostSummary> getPosts(int page, int size) {
        PageRequest pageable = PageRequest.of(page, size,
                Sort.by("visitDate").descending().and(Sort.by("createdAt").descending()));
        return pointVisitRepository.findPublicPosts(pageable)
                .map(CommunityPostSummary::new);
    }

    public CommunityPostDetail getPost(Long visitId) {
        return pointVisitRepository.findPublicById(visitId)
                .map(CommunityPostDetail::new)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않거나 비공개 일지입니다."));
    }
}
