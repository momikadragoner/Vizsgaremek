import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { AuthService } from '../account-forms/services/auth.service';


@Injectable()
export class PictureService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  rootURL = '/api';

  httpOptions = {
    headers: new HttpHeaders({
      'Authorization': `Bearer ${this.authService.getToken()}`
    })
  };

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }

  addPicture(picture:FormData) {
    return this.http.post<FormData>(this.rootURL + '/picture/product-picture', picture, this.httpOptions)
      .pipe(
        catchError((error) => this.handleError(error))
      );
  }

  private handleError(error: HttpErrorResponse) {
    if (error.status === 0) {
      // A client-side or network error occurred. Handle it accordingly.
      console.error('An error occurred:', error.error);
    } else {
      // The backend returned an unsuccessful response code.
      // The response body may contain clues as to what went wrong.
      console.error(
        `Backend returned code ${error.status}, body was: `, error.error);
    }
    // Return an observable with a user-facing error message.
    return throwError(() =>
      'Something bad happened; please try again later.');
  }

}
