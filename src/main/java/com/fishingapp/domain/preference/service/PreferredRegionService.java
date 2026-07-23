package com.fishingapp.domain.preference.service;

import com.fishingapp.domain.preference.dto.PreferredFishSpeciesRequest;
import com.fishingapp.domain.preference.dto.PreferredRegionRequest;
import com.fishingapp.domain.preference.dto.PreferredRegionResponse;
import com.fishingapp.domain.preference.entity.PreferredFishSpecies;
import com.fishingapp.domain.preference.entity.PreferredRegion;
import com.fishingapp.domain.preference.repository.PreferredRegionRepository;
import com.fishingapp.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PreferredRegionService {

    private final PreferredRegionRepository preferredRegionRepository;

    @Transactional
    public PreferredRegionResponse create(User user, PreferredRegionRequest request) {
        if (request.isDefault()) {
            unsetOtherDefaults(user, null);
        }

        PreferredRegion region = PreferredRegion.builder()
                .user(user)
                .name(request.getName())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .address(request.getAddress())
                .isDefault(request.isDefault())
                .build();
        region.replaceSpecies(toSpeciesEntities(request.getSpecies()));

        return new PreferredRegionResponse(preferredRegionRepository.save(region));
    }

    public List<PreferredRegionResponse> findAll(User user) {
        return preferredRegionRepository.findAllByUserOrderByCreatedAtDesc(user)
                .stream()
                .map(PreferredRegionResponse::new)
                .toList();
    }

    @Transactional
    public PreferredRegionResponse update(User user, Long regionId, PreferredRegionRequest request) {
        PreferredRegion region = getOwned(user, regionId);
        if (request.isDefault()) {
            unsetOtherDefaults(user, regionId);
        }

        region.update(request.getName(), request.getLatitude(), request.getLongitude(),
                request.getAddress(), request.isDefault());
        region.replaceSpecies(toSpeciesEntities(request.getSpecies()));

        return new PreferredRegionResponse(region);
    }

    @Transactional
    public void delete(User user, Long regionId) {
        preferredRegionRepository.delete(getOwned(user, regionId));
    }

    // 지역별 어종 목록 중 기본으로 표시된 게 여러 개 오면 첫 번째만 남기고 나머지는 해제
    // (프론트가 라디오 버튼으로 하나만 고르게 하지만 방어적으로 한 번 더 확인)
    private List<PreferredFishSpecies> toSpeciesEntities(List<PreferredFishSpeciesRequest> requests) {
        if (requests == null) return List.of();
        boolean[] defaultUsed = {false};
        return requests.stream()
                .map(r -> {
                    boolean asDefault = r.isDefault() && !defaultUsed[0];
                    if (asDefault) defaultUsed[0] = true;
                    return PreferredFishSpecies.builder()
                            .speciesName(r.getSpeciesName())
                            .isDefault(asDefault)
                            .build();
                })
                .toList();
    }

    // 사용자의 다른 선호 지역에 걸려있던 기본 표시를 해제 (한 사용자당 기본 지역은 하나뿐)
    private void unsetOtherDefaults(User user, Long excludeRegionId) {
        preferredRegionRepository.findAllByUserOrderByCreatedAtDesc(user).stream()
                .filter(PreferredRegion::isDefault)
                .filter(r -> !r.getId().equals(excludeRegionId))
                .forEach(PreferredRegion::clearDefault);
    }

    private PreferredRegion getOwned(User user, Long regionId) {
        return preferredRegionRepository.findByIdAndUser(regionId, user)
                .orElseThrow(() -> new IllegalArgumentException("선호 지역을 찾을 수 없습니다."));
    }
}
