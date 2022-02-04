import { Injectable } from '@angular/core';
import { AuthService } from './auth.service';
import { Router, CanActivate } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AuthGuardService implements CanActivate{

  constructor(private _router:Router, private _auth:AuthService) { }

  
    canActivate(){
      console.log(this._auth.getUserDetails())
      if(this._auth.getUserDetails() != null){
          return true;
      } else{
        this._router.navigate(['login']);
        return false;
      }
  
    }
}

