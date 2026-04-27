package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.CategoryRequest;
import com.brahim.eventhub.dto.CategoryResponse;

import java.util.List;

/**
 * Service interface for category operations.
 *
 * @author EventHub Team
 */
public interface CategoryService {
    List<CategoryResponse> getAllCategories();
    CategoryResponse createCategory(CategoryRequest request);
}