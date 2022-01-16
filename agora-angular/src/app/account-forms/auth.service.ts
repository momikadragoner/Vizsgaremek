import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';


@Injectable({
  providedIn: 'root'
})
export class AuthService {

  constructor(private http:HttpClient) { }

  public isAuthenticated() : Boolean{
    let userData = localStorage.getItem('userInfo')
    if(userData && JSON.parse(userData)){
      
      return true;
    }
    return false;
  }

  public setUserInfo(user:any){
    localStorage.setItem('userInfo',JSON.stringify(user))
  }

  public validate(email:String, password:String){
    
    return this.http.post('/api/authenticate',{'emailAddress':email, 'password':password}).toPromise()
  }
}
