package com.fishingapp.domain.point.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "point_visits")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class PointVisit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fishing_point_id", nullable = false)
    private FishingPoint fishingPoint;

    @Column(nullable = false)
    private LocalDate visitDate;

    // 같은 포인트라도 방문할 때마다 실제로 낚시한 지점이 조금씩 다를 수 있어 방문기록마다 별도로 저장한다.
    // null이면 포인트의 대표 위치를 그대로 사용한다는 뜻.
    private Double latitude;
    private Double longitude;

    @Column(length = 500)
    private String memo;

    @Column(length = 200)
    private String title;

    @Column(length = 5000)
    private String content;

    @Column(nullable = false)
    private boolean isPublic = false;

    @Embedded
    private WeatherInfo weather;

    @Embedded
    private TideInfo tide;

    @OneToMany(mappedBy = "pointVisit", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TackleEntry> tackles = new ArrayList<>();

    @OneToMany(mappedBy = "pointVisit", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CatchRecord> catches = new ArrayList<>();

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Builder
    public PointVisit(FishingPoint fishingPoint, LocalDate visitDate, Double latitude, Double longitude,
                      String memo, String title, String content, boolean isPublic,
                      WeatherInfo weather, TideInfo tide) {
        this.fishingPoint = fishingPoint;
        this.visitDate = visitDate;
        this.latitude = latitude;
        this.longitude = longitude;
        this.memo = memo;
        this.title = title;
        this.content = content;
        this.isPublic = isPublic;
        this.weather = weather;
        this.tide = tide;
    }

    public void addTackle(TackleEntry tackle) {
        tackle.assignTo(this);
        this.tackles.add(tackle);
    }

    public void replaceTackles(List<TackleEntry> newTackles) {
        this.tackles.clear();
        newTackles.forEach(this::addTackle);
    }

    public void addCatch(CatchRecord catchRecord) {
        catchRecord.assignTo(this);
        this.catches.add(catchRecord);
    }

    public void replaceCatches(List<CatchRecord> newCatches) {
        this.catches.clear();
        newCatches.forEach(this::addCatch);
    }

    public void update(LocalDate visitDate, Double latitude, Double longitude,
                       String memo, String title, String content, boolean isPublic) {
        this.visitDate = visitDate;
        this.latitude = latitude;
        this.longitude = longitude;
        this.memo = memo;
        this.title = title;
        this.content = content;
        this.isPublic = isPublic;
    }
}
