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

    @Column(length = 500)
    private String memo;

    @Embedded
    private WeatherInfo weather;

    @Embedded
    private TideInfo tide;

    @OneToMany(mappedBy = "pointVisit", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TackleEntry> tackles = new ArrayList<>();

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Builder
    public PointVisit(FishingPoint fishingPoint, LocalDate visitDate, String memo,
                      WeatherInfo weather, TideInfo tide) {
        this.fishingPoint = fishingPoint;
        this.visitDate = visitDate;
        this.memo = memo;
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

    public void update(LocalDate visitDate, String memo) {
        this.visitDate = visitDate;
        this.memo = memo;
    }
}
