package com.fishingapp.domain.community.repository;

import com.fishingapp.domain.community.entity.Comment;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findAllByPointVisitOrderByCreatedAtAsc(PointVisit pointVisit);
    Optional<Comment> findByIdAndUser(Long id, User user);
    long countByPointVisit(PointVisit pointVisit);
}
