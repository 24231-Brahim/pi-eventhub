package com.brahim.eventhub.dto;

/**
 * Response DTO for Category entity.
 *
 * @author EventHub Team
 */
public class CategoryResponse {
    private Integer id;
    private String name;

    public CategoryResponse() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private final CategoryResponse response = new CategoryResponse();

        public Builder id(Integer id) { response.id = id; return this; }
        public Builder name(String name) { response.name = name; return this; }
        public CategoryResponse build() { return response; }
    }
}