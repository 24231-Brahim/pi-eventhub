package com.eventhub.service;

import com.eventhub.dto.CategoryRequest;
import com.eventhub.model.Category;
import com.eventhub.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    public Category createCategory(CategoryRequest request) {
        Category category = Category.builder()
                .name(request.getName())
                .build();
        return categoryRepository.save(category);
    }
}
