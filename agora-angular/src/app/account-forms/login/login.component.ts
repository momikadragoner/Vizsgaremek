import { Component, OnInit } from '@angular/core';
import { FormGroup, Validators, FormControl } from '@angular/forms';
import { NgForm } from '@angular/forms';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {

  errorMessage = ""

  constructor(
    private _api: ApiService,
    private _auth: AuthService,
    private _router: Router) { }

  ngOnInit() {

  }

  onSubmit(form: NgForm) {
    this._api.postTypeRequest('user/login', form.value).subscribe({
      next: (res: any) => {
        if (res.status) {
          this._auth.setDataInLocalStorage('userData', JSON.stringify(res.data));
          this._auth.setDataInLocalStorage('token', res.token);
          this._router.navigate(['/']);
        }
      }, error: (err) => {
        this.errorMessage = err['error'].message;
      }
    });
  }
}
