package com.example.studentproject.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.Set;

@Entity
@Table(name = "students")
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String email;
    private Integer age;

    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id")
    )
    @JsonIgnoreProperties("students")
    private Set<Course> courses;

    public Long getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public Integer getAge() { return age; }
    public Set<Course> getCourses() { return courses; }

    public void setId(Long id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setEmail(String email) { this.email = email; }
    public void setAge(Integer age) { this.age = age; }
    public void setCourses(Set<Course> courses) { this.courses = courses; }
}