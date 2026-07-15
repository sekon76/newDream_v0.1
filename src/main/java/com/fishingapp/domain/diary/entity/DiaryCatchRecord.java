package com.fishingapp.domain.diary.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Entity
@Table(name = "diary_catch_records")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class DiaryCatchRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "diary_id", nullable = false)
    private Diary diary;

    @Column(nullable = false)
    private String fishName;

    @Column(nullable = false)
    private Integer count;

    private Integer sizeCm;

    private Integer weightG;

    private LocalTime caughtTime;

    @Builder
    public DiaryCatchRecord(String fishName, Integer count, Integer sizeCm, Integer weightG, LocalTime caughtTime) {
        this.fishName = fishName;
        this.count = count;
        this.sizeCm = sizeCm;
        this.weightG = weightG;
        this.caughtTime = caughtTime;
    }

    void assignTo(Diary diary) {
        this.diary = diary;
    }
}
