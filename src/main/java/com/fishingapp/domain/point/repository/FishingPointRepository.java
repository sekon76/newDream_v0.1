package com.fishingapp.domain.point.repository;

import com.fishingapp.domain.point.entity.FishingPoint;
import com.fishingapp.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FishingPointRepository extends JpaRepository<FishingPoint, Long> {
    List<FishingPoint> findAllByUserOrderByCreatedAtDesc(User user);
    Optional<FishingPoint> findByIdAndUser(Long id, User user);
}
