package com.fishingapp.domain.community.dto;

import lombok.Getter;

@Getter
public class LikeResponse {
    private final long likeCount;
    private final boolean liked;

    public LikeResponse(long likeCount, boolean liked) {
        this.likeCount = likeCount;
        this.liked = liked;
    }
}
