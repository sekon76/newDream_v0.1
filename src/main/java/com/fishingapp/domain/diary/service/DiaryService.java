package com.fishingapp.domain.diary.service;

import com.fishingapp.domain.diary.dto.*;
import com.fishingapp.domain.diary.entity.Diary;
import com.fishingapp.domain.diary.entity.DiaryCatchRecord;
import com.fishingapp.domain.diary.entity.DiaryTackleEntry;
import com.fishingapp.domain.diary.repository.DiaryRepository;
import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.point.entity.WeatherInfo;
import com.fishingapp.domain.point.repository.FishingPointRepository;
import com.fishingapp.domain.user.entity.User;
import com.fishingapp.global.external.TideClient;
import com.fishingapp.global.external.WeatherClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DiaryService {

    private final DiaryRepository diaryRepository;
    private final FishingPointRepository fishingPointRepository;
    private final WeatherClient weatherClient;
    private final TideClient tideClient;

    @Transactional
    public DiaryResponse create(User user, DiaryCreateRequest request) {
        FishingPoint point = request.getPointId() != null
                ? getOwnedPoint(user, request.getPointId())
                : null;
        boolean hasLocation = request.getLatitude() != null && request.getLongitude() != null;
        WeatherInfo weather = hasLocation
                ? weatherClient.fetch(request.getLatitude(), request.getLongitude(), request.getVisitDate())
                : null;
        TideInfo tide = hasLocation
                ? tideClient.fetch(request.getLatitude(), request.getLongitude(), request.getVisitDate())
                : null;

        Diary diary = Diary.builder()
                .user(user)
                .fishingPoint(point)
                .visitDate(request.getVisitDate())
                .title(request.getTitle())
                .content(request.getContent())
                .memo(request.getMemo())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .address(request.getAddress())
                .weather(weather)
                .tide(tide)
                .build();

        addTackles(diary, request.getTackles());
        addCatches(diary, request.getCatches());

        return new DiaryResponse(diaryRepository.save(diary));
    }

    public List<DiaryResponse> findAll(User user) {
        return diaryRepository.findAllByUserOrderByVisitDateDesc(user)
                .stream()
                .map(DiaryResponse::new)
                .toList();
    }

    public DiaryResponse findOne(User user, Long diaryId) {
        return new DiaryResponse(getOwnedDiary(user, diaryId));
    }

    @Transactional
    public DiaryResponse update(User user, Long diaryId, DiaryUpdateRequest request) {
        Diary diary = getOwnedDiary(user, diaryId);
        diary.update(request.getVisitDate(), request.getTitle(), request.getContent(), request.getMemo());

        if (request.getTackles() != null) {
            List<DiaryTackleEntry> newTackles = request.getTackles().stream()
                    .map(DiaryTackleEntryRequest::toEntity)
                    .toList();
            diary.replaceTackles(newTackles);
        }

        if (request.getCatches() != null) {
            List<DiaryCatchRecord> newCatches = request.getCatches().stream()
                    .map(DiaryCatchRequest::toEntity)
                    .toList();
            diary.replaceCatches(newCatches);
        }

        return new DiaryResponse(diary);
    }

    @Transactional
    public void delete(User user, Long diaryId) {
        diaryRepository.delete(getOwnedDiary(user, diaryId));
    }

    private void addTackles(Diary diary, List<DiaryTackleEntryRequest> tackles) {
        if (tackles == null) return;
        tackles.stream().map(DiaryTackleEntryRequest::toEntity).forEach(diary::addTackle);
    }

    private void addCatches(Diary diary, List<DiaryCatchRequest> catches) {
        if (catches == null) return;
        catches.stream().map(DiaryCatchRequest::toEntity).forEach(diary::addCatch);
    }

    private FishingPoint getOwnedPoint(User user, Long pointId) {
        return fishingPointRepository.findByIdAndUser(pointId, user)
                .orElseThrow(() -> new IllegalArgumentException("포인트를 찾을 수 없습니다."));
    }

    private Diary getOwnedDiary(User user, Long diaryId) {
        return diaryRepository.findByIdAndUser(diaryId, user)
                .orElseThrow(() -> new IllegalArgumentException("일지를 찾을 수 없습니다."));
    }
}
