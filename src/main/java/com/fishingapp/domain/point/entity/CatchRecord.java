package com.fishingapp.domain.point.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "catch_records")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CatchRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "point_visit_id", nullable = false)
    private PointVisit pointVisit;

    @Column(nullable = false)
    private String fishName;

    @Column(nullable = false)
    private Integer count;

    private Integer sizeCm;

    private Integer weightG;

    @Builder
    public CatchRecord(String fishName, Integer count, Integer sizeCm, Integer weightG) {
        this.fishName = fishName;
        this.count = count;
        this.sizeCm = sizeCm;
        this.weightG = weightG;
    }

    void assignTo(PointVisit visit) {
        this.pointVisit = visit;
    }
}
