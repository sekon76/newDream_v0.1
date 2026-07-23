package com.fishingapp.domain.preference.entity;

import com.fishingapp.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

// 조과예측 화면에서 자동으로 검색할 "선호 지역". 여러 개 등록 가능하며,
// 그중 정확히 하나만 isDefault=true로 표시되어 첫 예측 조회 시 사용된다.
@Entity
@Table(name = "preferred_regions")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class PreferredRegion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private String address;

    @Column(nullable = false)
    private boolean isDefault;

    @OneToMany(mappedBy = "preferredRegion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PreferredFishSpecies> species = new ArrayList<>();

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Builder
    public PreferredRegion(User user, String name, Double latitude, Double longitude, String address, boolean isDefault) {
        this.user = user;
        this.name = name;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.isDefault = isDefault;
    }

    public void update(String name, Double latitude, Double longitude, String address, boolean isDefault) {
        this.name = name;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.isDefault = isDefault;
    }

    public void clearDefault() {
        this.isDefault = false;
    }

    public void addSpecies(PreferredFishSpecies fishSpecies) {
        fishSpecies.assignTo(this);
        this.species.add(fishSpecies);
    }

    public void replaceSpecies(List<PreferredFishSpecies> newSpecies) {
        this.species.clear();
        newSpecies.forEach(this::addSpecies);
    }
}
