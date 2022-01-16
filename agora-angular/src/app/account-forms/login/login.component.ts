import { Component, OnInit } from '@angular/core';
import { FormGroup, Validators, FormControl } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { AuthService } from '../auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  userEmail:String="";
  userPassword:String="";
    
    
    
  constructor(private authService: AuthService, private router: Router) { }

  ngOnInit(){
    
  }

  login(){
    this.authService.validate(this.userEmail, this.userPassword)
    .then((response:any)=>{
      this.authService.setUserInfo({'user': response['user']});
      this.router.navigate(['']);
    })
    
  }

  

}
