package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.service.FileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    private final FileService fileService;

    @PostMapping("/upload")
    public Result<Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) {
        String imageUrl = fileService.uploadImage(file);
        String thumbUrl = fileService.generateThumbnail(file);
        return Result.success(Map.of("imageUrl", imageUrl, "thumbUrl", thumbUrl));
    }
}
