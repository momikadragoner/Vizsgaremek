import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validator, Validators } from '@angular/forms';
import { NgForm } from '@angular/forms';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-signup-customer',
  templateUrl: './signup-customer.component.html',
  styleUrls: ['./signup-customer.component.scss']
})
export class SignupCustomerComponent implements OnInit {
 
  errorMessage=""

  constructor(private _api:ApiService, private _auth:AuthService, private _router:Router) { }

  ngOnInit(){
   
  }

  onSubmit(form:NgForm){
    this._api.postTypeRequest('user/signup', form.value).subscribe((res:any)=>{
      if(res.status){
        this._auth.setDataInLocalStorage('userData',JSON.stringify(res.data));
        this._auth.setDataInLocalStorage('token', res.token);
        this._router.navigate(['login']);
      } else{
        alert(res.msg)
      }
    },err=>{
      this.errorMessage=err['error'].message;
    });
  }

  

  

}