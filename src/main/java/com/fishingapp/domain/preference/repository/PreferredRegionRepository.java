package com.fishingapp.domain.preference.repository;

import com.fishingapp.domain.preference.entity.PreferredRegion;
import com.fishingapp.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PreferredRegionRepository extends JpaRepository<PreferredRegion, Long> {
    List<PreferredRegion> findAllByUserOrderByCreatedAtDesc(User user);
    Optional<PreferredRegion> findByIdAndUser(Long id, User user);
}
