package com.fishingapp.domain.point.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "tackle_entries")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TackleEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "point_visit_id", nullable = false)
    private PointVisit pointVisit;

    private String tackleType;   // 채비 종류 (루어, 찌낚시, 바닥채비, 원투낚시 등)
    private String bait;         // 미끼 (지렁이, 크릴, 민물새우 등)
    private String fishCaught;   // 잡은 어종
    private Integer catchCount;  // 마릿수
    private String memo;

    @Builder
    public TackleEntry(String tackleType, String bait, String fishCaught, Integer catchCount, String memo) {
        this.tackleType = tackleType;
        this.bait = bait;
        this.fishCaught = fishCaught;
        this.catchCount = catchCount;
        this.memo = memo;
    }

    void assignTo(PointVisit visit) {
        this.pointVisit = visit;
    }
}
