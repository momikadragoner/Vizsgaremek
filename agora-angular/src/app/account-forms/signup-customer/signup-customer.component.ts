import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validator, Validators } from '@angular/forms';
import { NgForm } from '@angular/forms';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';
import { Router } from '@angular/router';
import { THIS_EXPR } from '@angular/compiler/src/output/output_ast';

@Component({
  selector: 'app-signup-customer',
  templateUrl: './signup-customer.component.html',
  styleUrls: ['./signup-customer.component.scss']
})
export class SignupCustomerComponent implements OnInit {

  errorMessage = ""
  isChecked:Boolean=false
  apiUrl:String=""

  constructor(
    private _api: ApiService,
    private _auth: AuthService,
    private _router: Router,
    private fb: FormBuilder
  ) { }

  signupForm = this.fb.group({
    lastName: ['', Validators.required],
    firstName: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(5)]]
  });

  ngOnInit() {

  }

  onSubmit() {
    if(this.isChecked==true){
      this.apiUrl='user/signupasvendor'
      
    } else{
      this.apiUrl='user/signup'
    }
    this._api.postTypeRequest(this.apiUrl, this.signupForm.value).subscribe({
      next: (res: any) => {
        if (res.status) {
          this._auth.setDataInLocalStorage('userData', JSON.stringify(res.data));
          this._auth.setDataInLocalStorage('token', res.token);
          this._router.navigate(['login']);
        } else {
          alert(res.msg)
        }
      },
      error: err => {
        this.errorMessage = err['error'].message;
      }
    });
  }

  onCheckboxChange(e:any){
    if(e.target.checked){
      return this.isChecked=true;
    }
    return this.isChecked=false;
  }
}
