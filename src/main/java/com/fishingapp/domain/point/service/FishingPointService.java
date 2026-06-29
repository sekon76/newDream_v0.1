package com.fishingapp.domain.point.service;

import com.fishingapp.domain.point.dto.PointCreateRequest;
import com.fishingapp.domain.point.dto.PointResponse;
import com.fishingapp.domain.point.dto.PointUpdateRequest;
import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.point.repository.FishingPointRepository;
import com.fishingapp.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FishingPointService {

    private final FishingPointRepository fishingPointRepository;

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
                .build();

        return new PointResponse(fishingPointRepository.save(point));
    }

    public List<PointResponse> findAll(User user) {
        return fishingPointRepository.findAllByUserOrderByCreatedAtDesc(user)
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
        point.update(
                request.getName(),
                request.getDescription(),
                request.getLatitude(),
                request.getLongitude(),
                request.getAddress(),
                request.getFishType(),
                request.getIsPublic()
        );
        return new PointResponse(point);
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
