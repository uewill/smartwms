package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FileService {

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    @Value("${file.thumbnail-width:200}")
    private int thumbnailWidth;

    @Value("${file.thumbnail-height:200}")
    private int thumbnailHeight;

    @Value("${file.compression-quality:0.8}")
    private float compressionQuality;

    public String uploadImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "上传文件不能为空");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "只能上传图片文件");
        }

        try {
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = UUID.randomUUID().toString().replace("-", "") + extension;

            Path filePath = uploadPath.resolve(filename);

            BufferedImage originalImage = ImageIO.read(file.getInputStream());
            if (originalImage == null) {
                throw new BusinessException(ErrorCode.BAD_REQUEST, "图片格式不支持");
            }

            saveCompressedImage(originalImage, filePath.toString(), compressionQuality);

            return "/uploads/" + filename;
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.INTERNAL_ERROR, "文件上传失败");
        }
    }

    public String generateThumbnail(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "上传文件不能为空");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "只能上传图片文件");
        }

        try {
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = "thumb_" + UUID.randomUUID().toString().replace("-", "") + extension;

            Path filePath = uploadPath.resolve(filename);

            BufferedImage originalImage = ImageIO.read(file.getInputStream());
            if (originalImage == null) {
                throw new BusinessException(ErrorCode.BAD_REQUEST, "图片格式不支持");
            }

            BufferedImage thumbnail = createThumbnail(originalImage, thumbnailWidth, thumbnailHeight);
            saveCompressedImage(thumbnail, filePath.toString(), compressionQuality);

            return "/uploads/" + filename;
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.INTERNAL_ERROR, "缩略图生成失败");
        }
    }

    private BufferedImage createThumbnail(BufferedImage original, int width, int height) {
        int originalWidth = original.getWidth();
        int originalHeight = original.getHeight();

        double scale = Math.min((double) width / originalWidth, (double) height / originalHeight);

        int scaledWidth = (int) (originalWidth * scale);
        int scaledHeight = (int) (originalHeight * scale);

        BufferedImage thumbnail = new BufferedImage(scaledWidth, scaledHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = thumbnail.createGraphics();
        g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2d.drawImage(original, 0, 0, scaledWidth, scaledHeight, null);
        g2d.dispose();

        return thumbnail;
    }

    private void saveCompressedImage(BufferedImage image, String filePath, float quality) throws IOException {
        File outputFile = new File(filePath);
        String formatName = "jpg";

        if (filePath.toLowerCase().endsWith(".png")) {
            formatName = "png";
        }

        java.util.Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName(formatName);
        if (!writers.hasNext()) {
            ImageIO.write(image, formatName, outputFile);
            return;
        }

        ImageWriter writer = writers.next();
        ImageWriteParam param = writer.getDefaultWriteParam();

        if (formatName.equals("jpg") && param.canWriteCompressed()) {
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(quality);
        }

        try (ImageOutputStream ios = ImageIO.createImageOutputStream(outputFile)) {
            writer.setOutput(ios);
            writer.write(null, new IIOImage(image, null, null), param);
        } finally {
            writer.dispose();
        }
    }
}
