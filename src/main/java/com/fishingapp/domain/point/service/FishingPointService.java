package com.fishingapp.domain.point.service;

import com.fishingapp.domain.point.dto.PointCreateRequest;
import com.fishingapp.domain.point.dto.PointResponse;
import com.fishingapp.domain.point.dto.PointUpdateRequest;
import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.point.repository.FishingPointRepository;
import com.fishingapp.domain.point.repository.PointVisitRepository;
import com.fishingapp.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FishingPointService {

    private final FishingPointRepository fishingPointRepository;
    private final PointVisitRepository pointVisitRepository;

    @Transactional
    public PointResponse create(User user, PointCreateRequest request) {
        FishingPoint point = FishingPoint.builder()
                .user(user)
                .name(request.getName())
                .description(request.getDescription())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .address(request.getAddress())
                .fishType(request.getFishType())
                .isPublic(request.isPublic())
                .communityOnly(request.isCommunityOnly())
                .build();

        fishingPointRepository.save(point);
        if (point.isPublic()) createPointPublicPost(point);

        return new PointResponse(point);
    }

    public List<PointResponse> findAll(User user) {
        return fishingPointRepository.findAllByUserAndCommunityOnlyFalseOrderByCreatedAtDesc(user)
                .stream()
                .map(PointResponse::new)
                .toList();
    }

    public PointResponse findOne(User user, Long pointId) {
        return new PointResponse(getOwnedPoint(user, pointId));
    }

    @Transactional
    public PointResponse update(User user, Long pointId, PointUpdateRequest request) {
        FishingPoint point = getOwnedPoint(user, pointId);
        boolean wasPublic = point.isPublic();
        point.update(
                request.getName(),
                request.getDescription(),
                request.getLatitude(),
                request.getLongitude(),
                request.getAddress(),
                request.getFishType(),
                request.getIsPublic()
        );
        if (!wasPublic && point.isPublic()) createPointPublicPost(point);
        return new PointResponse(point);
    }

    // 포인트가 공개로 전환되면, 커뮤니티에 노출할 안내 게시글(방문기록)을 자동으로 등록한다.
    private void createPointPublicPost(FishingPoint point) {
        StringBuilder content = new StringBuilder();
        if (point.getAddress() != null && !point.getAddress().isBlank()) {
            content.append("위치: ").append(point.getAddress()).append("\n");
        }
        if (point.getFishType() != null && !point.getFishType().isBlank()) {
            content.append("주요 어종: ").append(point.getFishType()).append("\n");
        }
        if (point.getDescription() != null && !point.getDescription().isBlank()) {
            content.append("\n").append(point.getDescription());
        }

        PointVisit visit = PointVisit.builder()
                .fishingPoint(point)
                .visitDate(LocalDate.now())
                .title("[포인트 공개]")
                .content(content.toString())
                .isPublic(true)
                .build();
        pointVisitRepository.save(visit);
    }

    @Transactional
    public void delete(User user, Long pointId) {
        FishingPoint point = getOwnedPoint(user, pointId);
        fishingPointRepository.delete(point);
    }

    // id + user 동시 조회 — 다른 사용자의 포인트 접근 원천 차단
    private FishingPoint getOwnedPoint(User user, Long pointId) {
        return fishingPointRepository.findByIdAndUser(pointId, user)
                .orElseThrow(() -> new IllegalArgumentException("포인트를 찾을 수 없습니다."));
    }
}
