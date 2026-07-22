package com.fishingapp.domain.point.service;

import com.fishingapp.domain.point.dto.*;
import com.fishingapp.domain.point.entity.CatchRecord;
import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.point.entity.TackleEntry;
import com.fishingapp.domain.point.repository.FishingPointRepository;
import com.fishingapp.domain.point.repository.PointVisitRepository;
import com.fishingapp.domain.user.entity.User;
import com.fishingapp.domain.point.entity.WeatherInfo;
import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.global.external.TideClient;
import com.fishingapp.global.external.WeatherClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PointVisitService {

    private final PointVisitRepository pointVisitRepository;
    private final FishingPointRepository fishingPointRepository;
    private final WeatherClient weatherClient;
    private final TideClient tideClient;

    @Transactional
    public PointVisitResponse create(User user, Long pointId, PointVisitCreateRequest request) {
        FishingPoint point = getOwnedPoint(user, pointId);
        boolean hasLocation = point.getLatitude() != null && point.getLongitude() != null;
        WeatherInfo weather = hasLocation
                ? weatherClient.fetch(point.getLatitude(), point.getLongitude(), request.getVisitDate())
                : null;
        TideInfo tide = hasLocation
                ? tideClient.fetch(point.getLatitude(), point.getLongitude(), request.getVisitDate())
                : null;

        PointVisit visit = PointVisit.builder()
                .fishingPoint(point)
                .visitDate(request.getVisitDate())
                .memo(request.getMemo())
                .title(request.getTitle())
                .content(request.getContent())
                .isPublic(request.isPublic())
                .weather(weather)
                .tide(tide)
                .build();

        if (request.getTackles() != null) {
            request.getTackles().stream()
                    .map(TackleEntryRequest::toEntity)
                    .forEach(visit::addTackle);
        }

        if (request.getCatches() != null) {
            request.getCatches().stream()
                    .map(CatchRecordRequest::toEntity)
                    .forEach(visit::addCatch);
        }

        return new PointVisitResponse(pointVisitRepository.save(visit));
    }

    public List<PointVisitResponse> findAll(User user, Long pointId) {
        FishingPoint point = getOwnedPoint(user, pointId);
        return pointVisitRepository.findAllByFishingPointOrderByVisitDateDesc(point)
                .stream()
                .map(PointVisitResponse::new)
                .toList();
    }

    public PointVisitResponse findOne(User user, Long pointId, Long visitId) {
        FishingPoint point = getOwnedPoint(user, pointId);
        return new PointVisitResponse(getOwnedVisit(point, visitId));
    }

    @Transactional
    public PointVisitResponse update(User user, Long pointId, Long visitId, PointVisitUpdateRequest request) {
        FishingPoint point = getOwnedPoint(user, pointId);
        PointVisit visit = getOwnedVisit(point, visitId);

        visit.update(request.getVisitDate(), request.getMemo(),
                request.getTitle(), request.getContent(), request.isPublic());

        if (request.getTackles() != null) {
            List<TackleEntry> newTackles = request.getTackles().stream()
                    .map(TackleEntryRequest::toEntity)
                    .toList();
            visit.replaceTackles(newTackles);
        }

        if (request.getCatches() != null) {
            List<CatchRecord> newCatches = request.getCatches().stream()
                    .map(CatchRecordRequest::toEntity)
                    .toList();
            visit.replaceCatches(newCatches);
        }

        return new PointVisitResponse(visit);
    }

    @Transactional
    public void delete(User user, Long pointId, Long visitId) {
        FishingPoint point = getOwnedPoint(user, pointId);
        pointVisitRepository.delete(getOwnedVisit(point, visitId));
    }

    private FishingPoint getOwnedPoint(User user, Long pointId) {
        return fishingPointRepository.findByIdAndUser(pointId, user)
                .orElseThrow(() -> new IllegalArgumentException("포인트를 찾을 수 없습니다."));
    }

    private PointVisit getOwnedVisit(FishingPoint point, Long visitId) {
        return pointVisitRepository.findByIdAndFishingPoint(visitId, point)
                .orElseThrow(() -> new IllegalArgumentException("방문 기록을 찾을 수 없습니다."));
    }
}
