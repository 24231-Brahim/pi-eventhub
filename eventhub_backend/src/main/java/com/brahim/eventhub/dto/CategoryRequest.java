package com.brahim.eventhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Request DTO for creating a category.
 *
 * @author EventHub Team
 */
public class CategoryRequest {

    @NotBlank(message = "Category name is required")
    @Size(min = 2, max = 100, message = "Category name must be between 2 and 100 characters")
    private String name;

    public CategoryRequest() {}

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
}