package com.example.map.pa1_2017314626;

import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintSet;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.EmbossMaskFilter;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;

import java.util.Arrays;
import java.util.Collections;

public class MainActivity extends AppCompatActivity {
    Bitmap imgpzl[][] = new Bitmap[3][3];
    Bitmap imgpzl2[][] = new Bitmap[4][4];
    Bitmap imgpzl3[] = new Bitmap[imgpzl[0].length*imgpzl.length];
    Bitmap imgpzl4[] = new Bitmap[imgpzl2[0].length*imgpzl2.length];
    Bitmap tmp;
    Bitmap answer[] = new Bitmap[9];
    Bitmap answer2[] = new Bitmap[16];

    Button button1;
    Button button2;
    Button button3;

    int check = 1;
    int pos = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        button1 = findViewById(R.id.button);
        button2 = findViewById(R.id.button2);
        button3 = findViewById(R.id.button3);


        Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.puzzle);
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++)
                imgpzl[i][j] = Bitmap.createBitmap(bitmap, j * (bitmap.getWidth()) / 3, i * (bitmap.getWidth()) / 3, bitmap.getWidth() / 3, bitmap.getHeight() / 3);
        }
        imgpzl[2][2] = Bitmap.createBitmap(bitmap, 0, 0, 1, 1);

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++)
                imgpzl2[i][j] = Bitmap.createBitmap(bitmap, j * (bitmap.getWidth()) / 4, i * (bitmap.getWidth()) / 4, bitmap.getWidth() / 4, bitmap.getHeight() / 4);
        }
        imgpzl2[3][3] = Bitmap.createBitmap(bitmap, 0, 0, 1, 1);

        for (int i=0; i<imgpzl.length; i++){
            for (int j=0; j<imgpzl[i].length; j++)
                imgpzl3[(i*imgpzl[i].length)+j]=imgpzl[i][j];
        }
        Bitmap white1 = imgpzl3[imgpzl3.length-1];

        for (int i=0; i<9; i++)
            answer[i] = imgpzl3[i];

        for (int i=0; i<imgpzl2.length; i++){
            for (int j=0; j<imgpzl2[i].length; j++)
                imgpzl4[(i*imgpzl2[i].length)+j]=imgpzl2[i][j];
        }
        Bitmap white2 = imgpzl4[imgpzl4.length-1];

        for (int i=0; i<16; i++)
            answer2[i] = imgpzl4[i];

        final GridView gridView = (GridView) findViewById(R.id.gridView);
        MyGridAdapter gAdapter = new MyGridAdapter(this);
        MyGridAdapter2 gAdapter2 = new MyGridAdapter2(this);
        gridView.setNumColumns(3);
        gridView.setAdapter(gAdapter);

        button1.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                for (int i=0; i<9; i++)
                    imgpzl3[i]=answer[i];
                gridView.setNumColumns(3);
                gridView.setAdapter(gAdapter);
            }
        });

        button2.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                for (int i=0; i<16; i++)
                    imgpzl4[i]=answer2[i];
                gridView.setNumColumns(4);
                gridView.setAdapter(gAdapter2);
            }
        });

        button3.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if (gridView.getNumColumns()==3) {
                    Collections.shuffle(Arrays.asList(imgpzl3));
                    gridView.setAdapter(gAdapter);
                }
            else if (gridView.getNumColumns()==4){
                    Collections.shuffle(Arrays.asList(imgpzl4));
                    gridView.setAdapter(gAdapter2);
            }
            }
        });

        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener(){
            public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
                pos =0;
                if (gridView.getNumColumns()==3){
                    if (position%3>0 ) {
                        if (imgpzl3[position - 1] == white1) {
                            tmp = imgpzl3[position - 1];
                            imgpzl3[position-1]=imgpzl3[position];
                            imgpzl3[position]=tmp;
                            pos = 1;
                        }
                    }

                    if (position%3<2){
                        if (imgpzl3[position+1]==white1){
                            tmp = imgpzl3[position+1];
                            imgpzl3[position+1]=imgpzl3[position];
                            imgpzl3[position]=tmp;
                            pos = 1;
                        }
                    }

                    if (position/3>0){
                        if (imgpzl3[position-3] == white1){
                            tmp = imgpzl3[position-3];
                            imgpzl3[position-3]=imgpzl3[position];
                            imgpzl3[position]=tmp;
                            pos = 1;
                        }
                    }

                    if (position/3<2){
                        if (imgpzl3[position+3] == white1){
                            tmp = imgpzl3[position+3];
                            imgpzl3[position+3]=imgpzl3[position];
                            imgpzl3[position]=tmp;
                            pos = 1;
                        }
                    }
                    check = 1;

                    for (int i=0; i<9; i++){
                        if (imgpzl3[i] != answer[i]) {
                            check = 0;
                            break;
                        }
                    }
                    if (check == 1 && pos == 1) {
                        Toast.makeText(getApplicationContext(), "FINISH!", Toast.LENGTH_LONG).show();
                    }

                    gridView.setAdapter(gAdapter);
                }

                else if (gridView.getNumColumns()==4){
                    if (position%4>0 ) {
                        if (imgpzl4[position - 1] == white2) {
                            tmp = imgpzl4[position - 1];
                            imgpzl4[position-1]=imgpzl4[position];
                            imgpzl4[position]=tmp;
                            pos = 1;
                        }
                    }

                    if (position%4<3){
                        if (imgpzl4[position+1]==white2){
                            tmp = imgpzl4[position+1];
                            imgpzl4[position+1]=imgpzl4[position];
                            imgpzl4[position]=tmp;
                            pos = 1;
                        }
                    }

                    if (position/4>0){
                        if (imgpzl4[position-4] == white2){
                            tmp = imgpzl4[position-4];
                            imgpzl4[position-4]=imgpzl4[position];
                            imgpzl4[position]=tmp;
                            pos = 1;
                        }
                    }

                    if (position/4<3){
                        if (imgpzl4[position+4] == white2){
                            tmp = imgpzl4[position+4];
                            imgpzl4[position+4]=imgpzl4[position];
                            imgpzl4[position]=tmp;
                            pos = 1;
                        }
                    }

                    check = 1;
                    for (int i=0; i<16; i++){
                        if (imgpzl4[i] != answer2[i]) {
                            check = 0;
                            break;
                        }
                    }
                    if (check == 1 && pos == 1) {
                        Toast.makeText(getApplicationContext(), "FINISH!", Toast.LENGTH_LONG).show();
                    }

                    gridView.setAdapter(gAdapter2);
                }

            }
        });



    }

    public class MyGridAdapter extends BaseAdapter {
        Context context;

        public MyGridAdapter(Context c) {
            context = c;
        }


        @Override
        public int getCount() {
            return 9;
        }

        @Override
        public Object getItem(int position) {
            return null;
        }

        @Override
        public long getItemId(int position) {
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ImageView view;
                view = new ImageView(context);
                view.setLayoutParams(new ViewGroup.LayoutParams(300,300));
                view.setScaleType(ImageView.ScaleType.FIT_CENTER);
                view.setPadding(2,2,2,2);

            view.setImageBitmap(imgpzl3[position]);

            return view;
        }

    }

    public class MyGridAdapter2 extends BaseAdapter {
        Context context;

        public MyGridAdapter2(Context c) {
            context = c;
        }


        @Override
        public int getCount() {
            return 16;
        }

        @Override
        public Object getItem(int position) {
            return null;
        }

        @Override
        public long getItemId(int position) {
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ImageView view;
            view = new ImageView(context);
            view.setLayoutParams(new ViewGroup.LayoutParams(225,225));
            view.setScaleType(ImageView.ScaleType.FIT_CENTER);
            view.setPadding(2,2,2,2);

            view.setImageBitmap(imgpzl4[position]);

            return view;
        }

    }


}
