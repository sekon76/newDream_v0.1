package com.fishingapp.domain.community.repository;

import com.fishingapp.domain.community.entity.PostLike;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PostLikeRepository extends JpaRepository<PostLike, Long> {
    boolean existsByPointVisitAndUser(PointVisit pointVisit, User user);
    Optional<PostLike> findByPointVisitAndUser(PointVisit pointVisit, User user);
    long countByPointVisit(PointVisit pointVisit);
}
