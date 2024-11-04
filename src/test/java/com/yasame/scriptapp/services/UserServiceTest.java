package com.yasame.scriptapp.services;

import com.yasame.scriptapp.dtos.requests.RegisterUserRequest;
import com.yasame.scriptapp.dtos.response.RegisterUserResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class UserServiceTest {
    @Autowired
    private UserService userService;

    @Test
    public void registerUserTest() {
        RegisterUserRequest request = new RegisterUserRequest();
        request.setUsername("jondoe");
        request.setPassword("password");
        RegisterUserResponse response = userService.registerUser(request);
        response.setMessage("Success");
        assertThat(response).isNotNull();
    }
}
