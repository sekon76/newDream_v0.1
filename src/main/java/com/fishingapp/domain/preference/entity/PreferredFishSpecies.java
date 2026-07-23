package com.fishingapp.domain.preference.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

// 선호 지역에 태그된 어종. 여러 개 등록 가능하지만, 조과예측 자동검색에는
// isDefault=true인 것 하나만 쓰인다. 어종 목록 자체는 백엔드에 카탈로그가
// 없고 Flutter 쪽 정적 목록(fish_species.dart)의 이름 문자열을 그대로 저장한다.
@Entity
@Table(name = "preferred_fish_species")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PreferredFishSpecies {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "preferred_region_id", nullable = false)
    private PreferredRegion preferredRegion;

    @Column(nullable = false)
    private String speciesName;

    @Column(nullable = false)
    private boolean isDefault;

    @Builder
    public PreferredFishSpecies(String speciesName, boolean isDefault) {
        this.speciesName = speciesName;
        this.isDefault = isDefault;
    }

    void assignTo(PreferredRegion preferredRegion) {
        this.preferredRegion = preferredRegion;
    }
}
