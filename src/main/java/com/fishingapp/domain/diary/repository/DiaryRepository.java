package com.fishingapp.domain.diary.repository;

import com.fishingapp.domain.diary.entity.Diary;
import com.fishingapp.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
    List<Diary> findAllByUserOrderByVisitDateDesc(User user);
    Optional<Diary> findByIdAndUser(Long id, User user);
}
