package com.fishingapp.domain.point.repository;

import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.point.entity.PointVisit;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PointVisitRepository extends JpaRepository<PointVisit, Long> {
    List<PointVisit> findAllByFishingPointOrderByVisitDateDesc(FishingPoint fishingPoint);
    Optional<PointVisit> findByIdAndFishingPoint(Long id, FishingPoint fishingPoint);

    @Query(value = "SELECT v FROM PointVisit v WHERE v.isPublic = true",
           countQuery = "SELECT COUNT(v) FROM PointVisit v WHERE v.isPublic = true")
    Page<PointVisit> findPublicPosts(Pageable pageable);

    @Query("SELECT v FROM PointVisit v WHERE v.id = :id AND v.isPublic = true")
    Optional<PointVisit> findPublicById(@Param("id") Long id);
}
