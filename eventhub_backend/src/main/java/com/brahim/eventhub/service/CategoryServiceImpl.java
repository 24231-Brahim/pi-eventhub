package com.brahim.eventhub.service;

import com.brahim.eventhub.dto.CategoryRequest;
import com.brahim.eventhub.dto.CategoryResponse;
import com.brahim.eventhub.exception.EmailAlreadyExistsException;
import com.brahim.eventhub.model.Category;
import com.brahim.eventhub.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementation of CategoryService for category operations.
 *
 * @author EventHub Team
 */
@Service
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryServiceImpl(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @Override
    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CategoryResponse createCategory(CategoryRequest request) {
        if (categoryRepository.existsByName(request.getName())) {
            throw new EmailAlreadyExistsException("Category already exists: " + request.getName());
        }

        Category category = Category.builder()
                .name(request.getName())
                .build();

        category = categoryRepository.save(category);
        return toResponse(category);
    }

    private CategoryResponse toResponse(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .build();
    }
}