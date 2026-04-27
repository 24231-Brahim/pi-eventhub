package com.brahim.eventhub.controller;

import com.brahim.eventhub.dto.*;
import com.brahim.eventhub.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for category endpoints.
 *
 * @author EventHub Team
 */
@RestController
@RequestMapping("/api/categories")
@Tag(name = "Categories", description = "Event category management endpoints")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    @Operation(summary = "Get all categories")
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getAllCategories() {
        List<CategoryResponse> categories = categoryService.getAllCategories();
        return ResponseEntity.ok(ApiResponse.success(categories));
    }

    @PostMapping
    @Operation(summary = "Create a new category")
    public ResponseEntity<ApiResponse<CategoryResponse>> createCategory(
            @Valid @RequestBody CategoryRequest request) {
        CategoryResponse response = categoryService.createCategory(request);
        return ResponseEntity.ok(ApiResponse.success("Category created successfully", response));
    }
}