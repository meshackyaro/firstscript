package com.yasame.scriptapp.data.repositories;

import com.yasame.scriptapp.data.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepositories extends JpaRepository<User, Long> {
}
