package com.fishingapp.domain.point.repository;

import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.point.entity.PointVisit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PointVisitRepository extends JpaRepository<PointVisit, Long> {
    List<PointVisit> findAllByFishingPointOrderByVisitDateDesc(FishingPoint fishingPoint);
    Optional<PointVisit> findByIdAndFishingPoint(Long id, FishingPoint fishingPoint);
}
