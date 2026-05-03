package com.example.studentproject.service;

import com.example.studentproject.entity.Course;
import com.example.studentproject.repository.CourseRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CourseService {

    private final CourseRepository repo;

    public CourseService(CourseRepository repo) {
        this.repo = repo;
    }

    public Course create(Course c) {
        return repo.save(c);
    }

    public List<Course> getAll() {
        return repo.findAll();
    }
}