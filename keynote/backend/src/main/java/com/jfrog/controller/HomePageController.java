package com.jfrog.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

@Controller
public class HomePageController {

    @RequestMapping(value="/",method = RequestMethod.GET)
    public ModelAndView gotoIndexPage(){

        return new ModelAndView(new RedirectView("/index.html", true));
    }

}