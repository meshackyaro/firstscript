package com.yasame.scriptapp.services;

import com.yasame.scriptapp.data.model.User;
import com.yasame.scriptapp.data.repositories.UserRepositories;
import com.yasame.scriptapp.dtos.requests.RegisterUserRequest;
import com.yasame.scriptapp.dtos.response.RegisterUserResponse;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepositories userRepositories;

    public UserService(UserRepositories userRepositories) {
        this.userRepositories = userRepositories;
    }

    public RegisterUserResponse registerUser(RegisterUserRequest request) {
        User user = new User();
        user.setUsername(request.getUsername().toLowerCase());
        user.setPassword(request.getPassword());
        userRepositories.save(user);

        RegisterUserResponse response = new RegisterUserResponse();
        response.setMessage("Success");
        return response;
    }
}
