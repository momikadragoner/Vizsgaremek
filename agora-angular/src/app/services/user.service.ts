import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '../account-forms/services/auth.service';

export interface User {
  userId: number,
  firstName: string,
  lastName: string,
  following: number,
  followers: number,
  email: string,
  phone: string,
  about: string,
  profileImgUrl: string,
  headerImgUrl: string,
  registeredAt: Date,
  isVendor: boolean,
  isAdmin: boolean,
  companyName?: string,
  siteLocation?: string,
  website?: string,
  takesCustomOrders?: boolean,
  iFollow?: boolean
}

export class User {
  /**
   *
   */
  constructor(
    public userId: number = 0,
    public firstName: string = '',
    public lastName: string = '',
    public following: number = -1,
    public followers: number = -1,
    public email: string = '',
    public phone: string = '',
    public about: string = '',
    public profileImgUrl: string = '',
    public headerImgUrl: string = '',
    public registeredAt: Date = new Date(),
    public isVendor: boolean = false,
    public isAdmin: boolean = false,
    public companyName?: string,
    public siteLocation?: string,
    public website?: string,
    public takesCustomOrders?: boolean,
    public iFollow?: boolean
  ) {
  }
}

export interface UserShort {
  userId: number,
  firstName: string,
  lastName: string,
  about: string,
  profileImgUrl: string,
  companyName?: string,
  takesCustomOrders?: boolean,
  iFollow?: boolean
}

export class UserShort {
  constructor(
    public userId: number = 0,
    public firstName: string = '',
    public lastName: string = '',
    public about: string = '',
    public profileImgUrl: string = '',
    public companyName?: string,
    public takesCustomOrders?: boolean,
    public iFollow?: boolean
  ) {
  }
}

@Injectable()
export class UserService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }
  isLoggedIn() {
    if (this.authService.getUserDetails()[0].member_id) {
      return true;
    }
    else {
      return false;
    }
  }
  rootURL = '/api';

  getUserShort(id: number) {
    let url = this.isLoggedIn() ? this.rootURL + '/user/' + id + "/short/auth/" + this.currentUserId() : this.rootURL + '/user/' + id + '/short';
    let token = localStorage.getItem('token') ? localStorage.getItem('token') : '';
    let headers = token ? new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }) : new HttpHeaders({ 'Content-Type': 'application/json' });
    return this.http.get<UserShort>(url, { headers: headers })
      .pipe(
        catchError(this.handleError)
      );
  }

  getUser(id: number = this.currentUserId()) {
    let token = localStorage.getItem('token') ? localStorage.getItem('token') : '';
    let headers = token ? new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }) : new HttpHeaders({ 'Content-Type': 'application/json' });
    let url = this.isLoggedIn() ? this.rootURL + '/user/' + id + "/auth/" + this.currentUserId() : this.rootURL + '/user/' + id;
    return this.http.get<User>(url, { headers: headers })
      .pipe(
        catchError(this.handleError)
      );
  }

  updateUser(user: User) {
    return this.http.put<object>(this.rootURL + '/user', user, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
      .pipe(
        catchError(this.handleError)
      );
  }

  getContacts(id: number = this.currentUserId()) {
    return this.http.get<[UserShort]>(this.rootURL + '/contacts/' + id, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
      .pipe(
        catchError(this.handleError)
      );
  }

  private handleError(error: HttpErrorResponse) {
    if (error.status === 0) {
      console.error('An error occurred:', error.error);
    } else {
      console.error(
        `Backend returned code ${error.status}, body was: `, error.error);
    }
    return throwError(() =>
      'Something bad happened; please try again later.');
  }

}
