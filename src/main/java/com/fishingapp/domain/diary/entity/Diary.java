package com.fishingapp.domain.diary.entity;

import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.point.entity.WeatherInfo;
import com.fishingapp.domain.user.entity.User;
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
@Table(name = "diaries")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class Diary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // 저장된 낚시 포인트와 선택적으로 연결. 포인트 없이도 일지를 쓸 수 있다.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fishing_point_id")
    private FishingPoint fishingPoint;

    @Column(nullable = false)
    private LocalDate visitDate;

    @Column(length = 200)
    private String title;

    @Column(length = 5000)
    private String content;

    @Column(length = 500)
    private String memo;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private String address;

    @Embedded
    private WeatherInfo weather;

    @Embedded
    private TideInfo tide;

    @OneToMany(mappedBy = "diary", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<DiaryTackleEntry> tackles = new ArrayList<>();

    @OneToMany(mappedBy = "diary", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<DiaryCatchRecord> catches = new ArrayList<>();

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Builder
    public Diary(User user, FishingPoint fishingPoint, LocalDate visitDate, String title, String content,
                 String memo, Double latitude, Double longitude, String address,
                 WeatherInfo weather, TideInfo tide) {
        this.user = user;
        this.fishingPoint = fishingPoint;
        this.visitDate = visitDate;
        this.title = title;
        this.content = content;
        this.memo = memo;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.weather = weather;
        this.tide = tide;
    }

    public void update(LocalDate visitDate, String title, String content, String memo) {
        this.visitDate = visitDate;
        this.title = title;
        this.content = content;
        this.memo = memo;
    }

    public void addTackle(DiaryTackleEntry tackle) {
        tackle.assignTo(this);
        this.tackles.add(tackle);
    }

    public void replaceTackles(List<DiaryTackleEntry> newTackles) {
        this.tackles.clear();
        newTackles.forEach(this::addTackle);
    }

    public void addCatch(DiaryCatchRecord catchRecord) {
        catchRecord.assignTo(this);
        this.catches.add(catchRecord);
    }

    public void replaceCatches(List<DiaryCatchRecord> newCatches) {
        this.catches.clear();
        newCatches.forEach(this::addCatch);
    }
}
