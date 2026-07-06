package com.fishingapp.domain.prediction.controller;

import com.fishingapp.domain.prediction.dto.HourlyPredictionResponse;
import com.fishingapp.domain.prediction.service.HourlyPredictionService;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/predictions/hourly")
@RequiredArgsConstructor
@Validated
public class HourlyPredictionController {

    private final HourlyPredictionService hourlyPredictionService;

    @GetMapping
    public ResponseEntity<HourlyPredictionResponse> predictHourly(
            @RequestParam @NotNull @DecimalMin("-90.0") @DecimalMax("90.0") Double lat,
            @RequestParam @NotNull @DecimalMin("-180.0") @DecimalMax("180.0") Double lon,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        LocalDate targetDate = (date != null) ? date : LocalDate.now();
        return ResponseEntity.ok(hourlyPredictionService.predict(lat, lon, targetDate));
    }
}
