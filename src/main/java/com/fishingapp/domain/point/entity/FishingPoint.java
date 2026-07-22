package com.fishingapp.domain.point.entity;

import com.fishingapp.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.ColumnDefault;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "fishing_points")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class FishingPoint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name;

    @Column(length = 500)
    private String description;

    // 커뮤니티 글쓰기는 위치 없이도 등록 가능해서 nullable
    private Double latitude;

    private Double longitude;

    private String address;

    private String fishType;

    @Column(nullable = false)
    private boolean isPublic;

    // 커뮤니티 글쓰기 화면에서 글을 담기 위한 용도로만 만들어진 포인트인지 여부.
    // true면 "내 포인트" 목록/일지의 포인트 선택 목록에서 제외한다.
    @Column(nullable = false)
    @ColumnDefault("false")
    private boolean communityOnly;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Builder
    public FishingPoint(User user, String name, String description, Double latitude, Double longitude,
                        String address, String fishType, boolean isPublic, boolean communityOnly) {
        this.user = user;
        this.name = name;
        this.description = description;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.fishType = fishType;
        this.isPublic = isPublic;
        this.communityOnly = communityOnly;
    }

    public void update(String name, String description, Double latitude, Double longitude,
                       String address, String fishType, boolean isPublic) {
        this.name = name;
        this.description = description;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.fishType = fishType;
        this.isPublic = isPublic;
    }
}
