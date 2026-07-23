package com.fishingapp.domain.user.service;

import com.fishingapp.domain.user.dto.AuthResponse;
import com.fishingapp.domain.user.dto.LoginRequest;
import com.fishingapp.domain.user.dto.PasswordChangeRequest;
import com.fishingapp.domain.user.dto.SignUpRequest;
import com.fishingapp.domain.user.entity.User;
import com.fishingapp.domain.user.entity.UserRole;
import com.fishingapp.domain.user.repository.UserRepository;
import com.fishingapp.global.config.JwtProperties;
import com.fishingapp.global.util.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final JwtProperties jwtProperties;
    private final RedisTemplate<String, String> redisTemplate;

    @Transactional
    public AuthResponse signup(SignUpRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .nickname(request.getNickname())
                .role(UserRole.ROLE_USER)
                .mapProvider(request.getMapProvider())
                .build();

        userRepository.save(user);

        return buildAuthResponse(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("이메일 또는 비밀번호가 올바르지 않습니다."));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("이메일 또는 비밀번호가 올바르지 않습니다.");
        }

        return buildAuthResponse(user);
    }

    public void logout(String token) {
        long remaining = jwtTokenProvider.getRemainingExpiration(token);
        if (remaining > 0) {
            redisTemplate.opsForValue().set("blacklist:" + token, "logout", remaining, TimeUnit.MILLISECONDS);
        }
    }

    @Transactional
    public void changePassword(User user, PasswordChangeRequest request) {
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalArgumentException("현재 비밀번호가 올바르지 않습니다.");
        }
        // @AuthenticationPrincipal로 들어온 User는 필터 단계에서 로딩된 detached 상태라
        // 이 트랜잭션의 영속성 컨텍스트 dirty checking 대상이 아니므로 명시적으로 저장한다.
        user.changePassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다: " + email));
    }

    private AuthResponse buildAuthResponse(User user) {
        return AuthResponse.builder()
                .accessToken(jwtTokenProvider.createToken(user.getEmail()))
                .tokenType("Bearer")
                .expiresIn(jwtProperties.getExpiration())
                .mapProvider(user.getMapProvider())
                .build();
    }
}
